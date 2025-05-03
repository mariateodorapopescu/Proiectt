package Servlet;

import java.io.IOException;
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
import bean.MyUser;

public class UpdateTaskStatusServlet extends HttpServlet {
    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1) Verificare sesiune și autentificare
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2) Preluare ierarhie utilizator și redirect daca NU e director
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("JDBC Driver not found", e);
        }
        try (Connection connCheck = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement psCheck = connCheck.prepareStatement(
                 "SELECT t.ierarhie, t.denumire AS functie FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE u.id = ?"
             )) {
            psCheck.setInt(1, currentUser.getId());
            try (ResultSet rs = psCheck.executeQuery()) {
                if (!rs.next()) {
                    response.sendRedirect("login.jsp");
                    return;
                }
                int ierarhie = rs.getInt("ierarhie");
                String functie = rs.getString("functie");
                boolean isDirector = (ierarhie < 3);
                boolean isSef       = (ierarhie >=4 && ierarhie <=5);
                boolean isIncepator = (ierarhie >=10);
                boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
                boolean isAdmin    = "Administrator".equals(functie);

                if (!isDirector) {
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
        } catch (SQLException e) {
            throw new ServletException("Database error during role check", e);
        }

        // 3) Preluare parametri
        int taskId      = Integer.parseInt(request.getParameter("task_id"));
        int newStatus   = Integer.parseInt(request.getParameter("status"));
        String comentariu = request.getParameter("comentariu");

        // 4) Load driver & establish connection via DriverManager
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("JDBC Driver not found", e);
        }

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {

            // 5) Verifică permisiuni: angajatul ori supervizor
            String sql = "SELECT * FROM tasks WHERE id = ? AND (id_ang = ? OR supervizor = ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, taskId);
                ps.setInt(2, currentUser.getId());
                ps.setInt(3, currentUser.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("management_taskuri.jsp?error=noPermission");
                        return;
                    }
                    int oldStatus   = rs.getInt("status");
                    int supervizorId = rs.getInt("supervizor");
                    String taskName = rs.getString("nume");

                    // 6) Actualizează statusul
                    String updateSql = "UPDATE tasks SET status = ? WHERE id = ?";
                    try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                        ups.setInt(1, newStatus);
                        ups.setInt(2, taskId);
                        ups.executeUpdate();
                    }

                    // 7) Notificări dacă s-a schimbat statusul
                    if (oldStatus != newStatus) {
                        String msg;
                        if (currentUser.getId() == rs.getInt("id_ang")) {
                            // notifică supervizor
                            msg = "Taskul '" + taskName + "' a fost actualizat la " 
                                  + getStatusText(newStatus) + "%. Comentariu: " 
                                  + (comentariu != null ? comentariu : "");
                            insertNotification(conn, taskId, supervizorId, msg);
                        } else {
                            // notifică angajat
                            int angajatId = rs.getInt("id_ang");
                            msg = "Statusul taskului '" + taskName + 
                                  "' a fost actualizat de supervizor la " 
                                  + getStatusText(newStatus) + "%. Comentariu: " 
                                  + (comentariu != null ? comentariu : "");
                            insertNotification(conn, taskId, angajatId, msg);
                        }
                        // notificare completare dacă 100%
                        if (newStatus == 4) {
                            notifyCompletion(conn, taskId, taskName);
                        }
                    }
                }
            }

            // 8) Redirect succes
            response.sendRedirect("management_taskuri.jsp?success=true");
        } catch (SQLException e) {
            throw new ServletException("Database error updating task status", e);
        }
    }

    private void insertNotification(Connection conn, int taskId, int userId, String message)
            throws SQLException {
        String sql = "INSERT INTO notificari_task (id_task, id_ang, tip_notificare, mesaj) " +
                     "VALUES (?, ?, 'ACTUALIZARE_STATUS', ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, taskId);
            ps.setInt(2, userId);
            ps.setString(3, message);
            ps.executeUpdate();
        }
    }

    private void notifyCompletion(Connection conn, int taskId, String taskName) throws SQLException {
        String getMgrSql = 
            "SELECT p.supervizor FROM tasks t " +
            "JOIN proiecte p ON t.id_prj = p.id " +
            "WHERE t.id = ?";
        try (PreparedStatement ps = conn.prepareStatement(getMgrSql)) {
            ps.setInt(1, taskId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int managerId = rs.getInt("supervizor");
                    String msg = "Taskul '" + taskName + "' a fost finalizat.";
                    insertNotification(conn, taskId, managerId, msg.replace("ACTUALIZARE_STATUS", "TASK_COMPLETAT"));
                }
            }
        }
    }

    private String getStatusText(int status) {
        switch (status) {
            case 0: return "0";
            case 1: return "25";
            case 2: return "50";
            case 3: return "75";
            case 4: return "100";
            default: return "0";
        }
    }
}
